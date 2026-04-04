cmd_arch/arm64/boot/dts/tinno6753_65t_m0.dtb := aarch64-linux-gnu-gcc -E -Wp,-MD,arch/arm64/boot/dts/.tinno6753_65t_m0.dtb.d.pre.tmp -nostdinc -I./arch/arm64/boot/dts -Iarch/arm64/boot/dts -I./arch/arm64/boot/dts/include -I./include/ -I./drivers/of/testcase-data -undef -D__DTS__ -x assembler-with-cpp -o arch/arm64/boot/dts/.tinno6753_65t_m0.dtb.dts.tmp arch/arm64/boot/dts/tinno6753_65t_m0.dts ; ./scripts/dtc/dtc -O dtb -o arch/arm64/boot/dts/tinno6753_65t_m0.dtb -b 0 -i arch/arm64/boot/dts/  -d arch/arm64/boot/dts/.tinno6753_65t_m0.dtb.d.dtc.tmp arch/arm64/boot/dts/.tinno6753_65t_m0.dtb.dts.tmp ; cat arch/arm64/boot/dts/.tinno6753_65t_m0.dtb.d.pre.tmp arch/arm64/boot/dts/.tinno6753_65t_m0.dtb.d.dtc.tmp > arch/arm64/boot/dts/.tinno6753_65t_m0.dtb.d

source_arch/arm64/boot/dts/tinno6753_65t_m0.dtb := arch/arm64/boot/dts/tinno6753_65t_m0.dts

deps_arch/arm64/boot/dts/tinno6753_65t_m0.dtb := \
  arch/arm64/boot/dts/mt6735.dtsi \
    $(wildcard include/config/addr.h) \
    $(wildcard include/config/base.h) \
  arch/arm64/boot/dts/include/dt-bindings/clock/mt6735-clk.h \
  arch/arm64/boot/dts/include/dt-bindings/interrupt-controller/arm-gic.h \
  arch/arm64/boot/dts/include/dt-bindings/interrupt-controller/irq.h \
  arch/arm64/boot/dts/mt6735-pinfunc.h \
  arch/arm64/boot/dts/include/dt-bindings/pinctrl/mt65xx.h \
  arch/arm64/boot/dts/include/dt-bindings/mmc/mt67xx-msdc.h \
  arch/arm64/boot/dts/trusty.dtsi \
  arch/arm64/boot/dts/include/dt-bindings/lcm/hx8392a_dsi_cmd.dtsi \
  arch/arm64/boot/dts/include/dt-bindings/lcm/lcm_define.h \

arch/arm64/boot/dts/tinno6753_65t_m0.dtb: $(deps_arch/arm64/boot/dts/tinno6753_65t_m0.dtb)

$(deps_arch/arm64/boot/dts/tinno6753_65t_m0.dtb):
