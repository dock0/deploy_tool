##
# Roll the new kernel

require 'FileUtils'

location = `roller.py \
  -s \
  -k #{@config['kernel']['version']} \
  -c #{@config['kernel']['version']} \
  -r #{@config['kernel']['revision']} \
  -b #{@config['kernel']['tmpdir']}/tmp \
  -d #{@config['kernel']['configs']}/kernels
`

FileUtils.mkdir_p "#{@config['paths']['mount']}/boot/grub"
FileUtils.cp location, "#{@config['paths']['mount']}/boot/vmlinuz"

FileUtils.mkdir_p "/lib/modules/#{@config['kernel']['version']}_#{@config['kernel']['revision']}"
`mkinitcpio \
  -c /dev/null \
  -A 'base,udev,lvm2,archiso' \
  -g #{@config['paths']['mount']}/boot/initrd.img \
  -k #{@config['kernel']['version']}_#{@config['kernel']['revision']}
`

kernel_options = @config['kernel']['options'].reduce('') { |a, (k, v)| a + "#{k}=#{v} " }

grub_config = "timeout 10
default 0

title dock0
root (hd0)
kernel /boot/vmlinuz #{kernel_options}
initrd /boot/initrd.img"

File.open("#{@config['paths']['mount']}/boot/grub/menu.lst", 'w') do |fh|
  fh.write grub_config
end
