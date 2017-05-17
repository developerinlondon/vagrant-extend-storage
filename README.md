# Vagrant::Extended-storage

A Vagrant plugin that extends the root storage by attaching a second volume and using lvmextend.

Requires lvm partitions.

## Installation

    $ vagrant plugin install vagrant-extended-storage

## Usage

After installing you can set the location and size of the extended storage.

The following options will create a extend storage with 5000 MB, named mysql,
mounted on /var/lib/mysql, in a volume group called 'vagrant'
```ruby
config.extended_storage.enabled = true
config.extended_storage.location = "~/development/sourcehdd.vdi"
config.extended_storage.size = 5000
config.extended_storage.filesystem = 'ext4'
config.extended_storage.volgroupname = 'vg_os'
```

With `config.extended_storage.mountoptions` you can change the mount options (default: defaults).  
A example which sets `prjquota` option with xfs.
```ruby
config.extended_storage.mountname    = 'root'
```

Device defaults to `/dev/sdb`. For boxes with multiple disks, make sure you increment the drive:
```
config.extended_storage.diskdevice = '/dev/sdc'
```

Every `vagrant up` will attach this file as hard disk to the guest machine.
An `vagrant destroy` will detach the storage to avoid deletion of the storage by vagrant.
A `vagrant destroy` generally destroys all attached drives. See [VBoxMange unregistervm --delete option][vboxmanage_delete].

The disk is initialized and added to the volume group specfied in the config; 


## Windows Guests

NOT TESTED or SUPPORTED. Get a Mac/Linux ffs.

## Troubleshooting

If your box are not using LVM you must set `config.extended_storage.use_lvm = false`. (currently we only support LVM)

## Supported Providers

* Only the VirtualBox provider is supported.

## Contributors

* [madAndroid](https://github.com/madAndroid)
* [Jeremiah Snapp](https://github.com/jeremiahsnapp)
* [Hiroya Ito](https://github.com/hiboma)
* [joshuata](https://github.com/joshuata)
* [Ciprian Zaharie](https://github.com/bucatzel)
* [aishahalim](https://github.com/aishahalim)
* [Dick Tang](https://github.com/dictcp)
* [dsmaher](https://github.com/dsmaher)
* [Marsup](https://github.com/Marsup)
* [k2s](https://github.com/k2s)
* [vvavrychuk](https://github.com/vvavrychuk)
* [Lars Hupfeldt Nielsen](https://github.com/lhupfeldt)
* [Chen Yu Pao](https://github.com/windperson)
* [Kris Reese](https://github.com/ktreese)
* [Henry N.](https://github.com/HenryNe)

## TODO

* There's Always Something to Do
* Add more options (controller, port, etc.)


[vboxmanage_delete]: http://www.virtualbox.org/manual/ch08.html#vboxmanage-registervm "VBoxManage registervm / unregistervm"
