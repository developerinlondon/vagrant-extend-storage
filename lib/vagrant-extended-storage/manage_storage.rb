require 'tempfile'
require 'fileutils'
require 'erb'

module VagrantPlugins
  module ExtendedStorage
    module ManageStorage
      def populate_template(m)
        mnt_name = m.config.extended_storage.mountname
        mnt_point = m.config.extended_storage.mountpoint
        mnt_options = m.config.extended_storage.mountoptions
        vg_name = m.config.extended_storage.volgroupname
        disk_dev = m.config.extended_storage.diskdevice
        fs_type = m.config.extended_storage.filesystem
        manage = m.config.extended_storage.manage
        use_lvm = m.config.extended_storage.use_lvm
        mount = m.config.extended_storage.mount
        format = m.config.extended_storage.format

		## windows filesystem options
		drive_letter = m.config.extended_storage.drive_letter

		if m.config.vm.communicator == :winrm
			os = "windows"
		else
			os = "linux"
		end

        vg_name = 'vps' unless vg_name != 0
        disk_dev = '/dev/sdb' unless disk_dev != 0
        mnt_name = 'vps' unless mnt_name != 0
        mnt_options = ['defaults'] unless mnt_options != 0
        fs_type = 'ext3' unless fs_type != 0
        if use_lvm
          device = "/dev/#{vg_name}/#{mnt_name}"
        else
          device = "#{disk_dev}1"
        end
		if drive_letter == 0
			drive_letter = ""
		else
			drive_letter = "letter=#{drive_letter}"
		end
		
		if os == "windows"
			## shell script for windows to create NTFS partition and assign drive letter
			disk_operations_template = ERB.new <<-EOF
			<% if format == true %>
			foreach ($disk in get-wmiobject Win32_DiskDrive -Filter "Partitions = 0"){
				$disk.DeviceID
				$disk.Index
				"select disk "+$disk.Index+"`r clean`r create partition primary`r format fs=ntfs unit=65536 quick`r active`r assign #{drive_letter}" | diskpart >> disk_operation_log.txt
			}
			<% end %>
			EOF
		else
		## shell script to format disk, create/manage LVM, mount disk
        disk_operations_template = ERB.new <<-EOF
#!/bin/bash
# fdisk the disk if it's not a block device already:
re='[0-9][.][0-9.]*[0-9.]*'; [[ $(sfdisk --version) =~ $re ]] && version="${BASH_REMATCH}"
if ! awk -v ver="$version" 'BEGIN { if (ver < 2.26 ) exit 1; }'; then
	[ -b #{disk_dev}1 ] || echo 0,,8e | sfdisk #{disk_dev}
else
	[ -b #{disk_dev}1 ] || echo ,,8e | sfdisk #{disk_dev}
fi
echo "fdisk returned:  $?" >> disk_operation_log.txt

<% if use_lvm == true %>
# Create the physical volume if it doesn't already exist:
[[ `pvs #{disk_dev}1` ]] || pvcreate #{disk_dev}1
echo "pvcreate returned:  $?" >> disk_operation_log.txt
# Extend the volume group :
vgextend #{vg_name} #{disk_dev}1
echo "vgextend returned:  $?" >> disk_operation_log.txt
# Extend LVM:
lvextend #{device} #{disk_dev}1
echo "lvextend returned:  $?" >> disk_operation_log.txt
# Resize on the fly
resize2fs #{device}
echo "resize2fs #{device} returned: $?" >> disk_operation_log.txt
# reserver 5%
tune2fs -m 5 /dev/mapper/#{vg_name}-#{mnt_name}
<% end %>

exit $?
        EOF
		end

        buffer = disk_operations_template.result(binding)
		tmp_script = Tempfile.new("disk_operations_#{mnt_name}.sh")

		if os == 'windows'
			target_script = "disk_operations_#{mnt_name}.ps1"
		else
			target_script = "/tmp/disk_operations_#{mnt_name}.sh"
		end

        File.open("#{tmp_script.path}", 'wb') do |f|
            f.write buffer
        end
        m.communicate.upload(tmp_script.path, target_script)
		unless os == 'windows'
			m.communicate.sudo("chmod 755 #{target_script}")
		end
      end

      def run_disk_operations(m)
        return unless m.communicate.ready?
        mnt_name = m.config.extended_storage.mountname
        mnt_name = 'vps' unless mnt_name != 0
		if m.config.vm.communicator == :winrm
			target_script = "disk_operations_#{mnt_name}.ps1"
			m.communicate.sudo("powershell -executionpolicy bypass -file #{target_script}")
		else
			target_script = "/tmp/disk_operations_#{mnt_name}.sh"
			m.communicate.sudo("#{target_script}")
		end

      end

      def manage_volumes(m)
        populate_template(m)
        if m.config.extended_storage.manage?
          run_disk_operations(m)
        end
      end

    end
  end
end
