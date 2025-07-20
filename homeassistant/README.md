# Home Assistant

## Open ports
sudo ufw allow 8123
sudo ufw allow 21064/tcp comment homekit

## Authentik

https://goauthentik.io/integrations/services/home-assistant/

## IR Remote

### Learn new command

1. View IR Remote page
2. In Device info section, click on 3 dots button -> Manage Zigbee device
3. In Manage Zigbee Device dialog -> Go to tab Clusters ->
4. In tab Clusters ->
  - Clusters: ZosungIRControl
5. In subtab Commands ->
  - Commands of the selected cluster: IRLearn
  - on_off: true
  - Click Issue Zigbee command
6. Point real remote to IR Remote, then press any button
7. In subtab Attributes
  - Attributes of the selected cluster: last_learned_ir_code
  - Click Read Attribute
8. Store the Value and repeat step 5, 6, 7 for other buttons
9. Open File editor addon
  - Open scripts.yaml
  - Update variables.config with your values
  ```yaml
  fake_remote:
  variables:
    config:
      living_led_on: B/gkrRF0Ai8C4AMDQAHgAw8DdAJ4BuAFA+AFEwQvAngGdGADAC9gAUAHQANAAeADBwR0AngGLyADQAfgBQMHb6H4JNEILwI=
      living_led_off: BdQk0BFLAuABAQKAAkvgCgEBeAbAAwCAYAtAAcALBXgGSwJLAuABF+ABAQKAAkugAYAjAUsCQAcCeAaAIANAB0ADgAsPYqHUJMMIgAL//9QkwwhLAg==
      living_led_decrease: BdokrxFMAuANAQKCAkygAQJ/BoIgA0AHgANAAcALwAcETAKCAkzgCAHgARPAJ+AJBwmCAi2h2iTCCEwC
      living_led_increase: CQAlnBFGAkYCfgKAA0ABQAtAAcAHBEYCfQZ+4AIDAUYCQAFAB4ADAn4CRuAIAeAFEwF9BsADAH7gDAsHR6EAJdYIRgI=
      living_led_white: Bg0luRF0AjRgAUAHQANAAUAH4AEDAXwGQAMANKAHAnQCNCABQAfgAQNAD0ADA3QCNALgAwNAAcAPQAEBdAJAI+AHAwe7og0l1wg0Ag==
      living_led_blue: CcQk0RFAAkACewKAA0ABwAtAB0ABBHsCfwZA4AIDCHsCQAJ7An8GQCADQAcIewJAAnsCfwZAYAMEQAJ7AkBgAUAHQAMDQAJ
      living_led_green: BQQlrBFIAuANAQJ7AkigAQKJBnvgAgMBSAJAAQGJBkATQAeAA0ABQAuAAQJ7AkjgBgHAG0AH4AcDBzOhBCW+CEgC
      living_led_red: CsAkpRE1AjUCbwI1YAFAB+ADA0ABA28CewZAAwA1oAcCbwI1IAFAB4ADBTUCNQJvAkAD4AELQAEBbwLAAwF7BoADQA/ACwJ7BjUgA0AHCW8CRaHAJNkINQI=
      living_led_flash: BgElsxF8AkTgCAFAE0ADgAEBfAbAAwB8YAtAAQB8oAsBfAbAAwF8AiAJCAJ8BkQCRAJ8AoAD4AMBBnwCfAZ8AkQgAQB8IAcAfGADQAsJRAJjoQElqgh8Ag==
      living_led_strobe: BgklsxFzAjpgAUAHQANAAeADBwRzAnwGOiADQAeAAwA6IAHACwF8BuADC4APBDoCcwI6YAFAB0ADQAHgAQeAJ0AHADpgCwdYoQkl3Qg6Ag==
      living_led_fade: Bt8krxF+AkngDAFAF4ADAnwGSSADwAcDSQJJAuABC0APwAMESQJ+AkkgAUAP4AEBgBNAAUAXQANAAUAHwAMHNaHfJLsISQI=
      living_led_smooth: BtoksxFuAjVgAUAH4AMDQAFADwQ1AnsGbqADgAsANSABwAsBewZAA0APQAcCbgI1IAGAB0AL4AcDATUCwBsBewaACwt7Bm4Cg6HaJKcIbgI=
      bed_ac_toggle: BygjpRE7AoQGgAPgAwEDEAI7AsAX4AsHQB9AAwGEBkAFQAPgBQEBhAbgAQNAAUAh4CMDwD/gIzPgAysBhAZADcABBBAChAY7YAMCEAI7IAEBEAJADwI7AhAgAUAF4AEDBYQG/QJWAUADQAtAGeAFAUARQAMDhAY7AkAH4BcDQAHAK8AHwDNAD0ABQAdAE+ADBws7AjsCEAI7AoQGOwI=
      bed_ac_increase: B2sjfxE8AowGgAMDPAIVAuADA8AXAYwG4AELBRUCPAKMBoADwAtAB+ADAwM8AhUCwCMFjAYVAjwC4AcDATwC4AcR4AcPAYwGQANAFQE8AoAFATwCQAfgHwMDjAY8AkArATwCQAUBFQJAD0ADARUCgAMBjAZACQKZAhVgAQE8AsADA4wGPAJACwM8AhUCgAsBFQJAC4ADATwCwAmAGwE8AuAfAwE8AuAJKeALQxOMBhUCPAIVAowGFQI8AjwCjAYVAg==
      bed_ac_decrease: B0UjpREqApIGgAPgBwHAF+ALB8ABQBvgCwFAF8AD4CsB4DM7QAFAP+ADAUAPQAPAAeADC+ADAeADF+ADC+AHAeATG+AHAeAPK8AXwAfAAeADDwOSBioC
      bed_ac_leftright: B0MjrBErApAGgAPgBwHAF+ALB8ABQBvgQQEDdgKwAUAFESsCkAawAZAGKwIrAnYCsAErAuAlAQF2AoA74AEBQA9AA8AB4AELAnYCK+ACAeABFwErAuADC+AHAeATG+AHAUArQAPgBwHAE0AHQAPAAUALC5AGKwIrAisCkAYrAg==
      bed_ac_updown: CD4jpRFhAo8GJiADBc8CiQEmAuADAQGPBoAD4AMBAY8GgC/AAQOPBiYC4BEBAWEC4AEDQAFAD+AdAUBXAY8G4CEv4AcBBY8GJgImAkA/gANAD0ADwAHgAwvgAwHgAxcFjwZhAiYCQAPgBwEKYQKPBiYCJgJhAiagAQFhAuEHPeAFAYAvgAEBYQKAA8ATQAdAA0AB4AgHAgYmAg==
      bed_ac_speed: B1QjphEqApAGQAMCXAIq4AYBAZAG4BEDwAEBkAbgCTdAAQGQBuABA+ArAQGQBuADV+ADC+ABAQOQBioC4A8B4AcbQA9AA8AB4AML4AMB4AMX4AML4AcB4BMb4BMB4AM34AMLwAFAE0ADCyoCKgIqAioCkAYqAg==
      bed_ac_cool: B00johEsAocGgAPgBwHAF+ALB8ABQBvgCwFAF8AD4CsBQDvgFwHgEyPgBxtAD0ADwAHgAwvgAwHgAxfgAwvgBwHgExvgCwFAL0AD4AMB4AMPQAtAA0ABwAcHLAIsAocGLAI=
  sequence:
  - delay:
      hours: 0
      minutes: 0
      seconds: 1
      milliseconds: 0
  - condition: template
    value_template: '{{ command is defined and command in config }}'
  - alias: Issue a command via the remote
    data:
      cluster_type: in
      command: 2
      endpoint_id: 1
      params:
        code: '{{ config.get(command) }}'
      cluster_id: 57348
      ieee: fc:4d:6a:ff:fe:36:b5:87
      command_type: server
    action: zha.issue_zigbee_cluster_command
  ```
  - Save and reload configurations