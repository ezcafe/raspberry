# Home Assistant

## Open ports
sudo ufw allow 8123
sudo ufw allow 21064/tcp comment homekit

## Authentik

https://goauthentik.io/integrations/services/home-assistant/

## Need automation inspiration? Ask AI!

In Developer Tools > Template, paste this template and copy the result to your clipboard:

```
{%- for area in areas() -%}
**Area: {{area_name(area)}}** (id: {{area}})
{%- for device in area_devices(area) %}
  - Device: {{device_name(device)}} (id: {{device}})
{%- for entity in device_entities(device) %}
    - {{entity}} (current state: {{states(entity, rounded=False, with_unit=True)}})
{%- endfor %}
{%- endfor %}
{% endfor %}
```

Write the following as your AI prompt for Claude/ChatGPT/Gemini/Deepseek:

In my Home Assistant setup, I have the following areas, devices, and entities (along with an example of their current state). Please recommend automations that I might find useful or clever. Consider if, based on the device or entity name, a specific integration is being used, and be sure to research documentation on that integration.

If there are any gaps in the information I've given you that may affect the quality of your recommendations, request additional information from me to clarify, and then proceed with your recommendations.

After your narrative list of recommendations, provide a concise numbered list of their names. If I respond with a single number, provide a comprehensive and well-researched YAML automation for the corresponding recommendation. Do not provide source code unless I have responded with a number or otherwise requested a specific automation.

Hints for automations:
- add an `alias` and concise `description` to the automation itself
- add an `alias` to its triggers, conditions, and actions
- consider using notifications, logbook entries, or trigger IDs for complex automations; or variables to manage complex state.

"""
(paste the output of step 1 here)
"""

## Tasmota-IRHVAC Remote

- Follow this guide to setup device https://www.youtube.com/watch?v=dhuiiHmfK8k
- Follow this guide to setup other IR commands https://github.com/hristo-atanasov/Tasmota-IRHVAC
- If there is issue, go to https://github.com/hristo-atanasov/Tasmota-IRHVAC/tree/master/custom_components/tasmota_irhvac and copy the new component

```scripts.yaml
irhvac_remote:
  sequence:
  - data_template:
      payload: '{"Protocol":"{{ protocol }}","Bits": {{ bits }},"Data": {{ data }},"DataLSB": {{ dataLSB }},"Repeat": {{ repeat }}}'
      topic: 'cmnd/{{ commandTopic }}/irsend'
    service: mqtt.publish
  alias: Script bedroom irhvac remote
  description: ''
```

```automation action
action: script.irhvac_remote
data:
  protocol: NEC
  bits: 32
  data: 0xFFA25D
  dataLSB: 0xFF45BA
  repeat: 0
  commandTopic: X_SMART_LINK_C9EF77
```

- Bedroom topic: X_SMART_LINK_C9EF77
- Working room topic: X_SMART_LINK_0CCB7B

cmnd/X_SMART_LINK_C9EF77/irsend {"Protocol":"NEC","Bits":32,"Data":"0xFFA25D","DataLSB":"0xFF45BA","Repeat":0}

- Follow this guide to setup presence sensor https://www.youtube.com/watch?v=F_2JeaVL49Q

## Broadlink Remote

### Setup device names in Broadlink app

### Learn new command

1. Go to "Developer tools" -> "Actions"
2. Select "Learn command"
3. Target -> Choose device -> Select Broadlink Remote
4. Device -> Input device name (set up in previous step "Setup device names in Broadlink app")
5. Command: Input command name
6. Command type: Select command type
7. Click "Perform action"
8. Point real remote to Broadlink Remote, then press button
9. Repeat step 5 to step 8 for other buttons

### Setup automation

1. Create new automation
2. Choose Send command and input information

### Review commands

1. Go to Add-ons -> File editor
2. Go to Configuration tab -> Remove .storage in "Ignore Pattern"
3. Save and restart
4. Open web UI
5. Go to .storage folder -> Open broadlink_remote_xxxxxx_codes

```json
{
  "version": 1,
  "minor_version": 1,
  "key": "broadlink_remote_b4430dc738fa_codes",
  "data": {
    "AC in bedroom": {
      "AC_Off": "JgDYAAABJZYROBE4ERMRExEUEBQROBE4ETkQORE4ETgRORAUERMROBETERQQFBETERMROBE5ETgRExETERQQFBAUERMRExETERQQFBETERMRExE5EDkRExETERMRFBAUERMRExETERMRFBAUERMRExETETkQFBETERMROBE5EBQRExE4ERMRFBAUERMRExE4ERQQFBE4ERMRExEUEBQRExETERMRFBAUERMRExETERMRFBAUERMRExE4ERQQORETERMRExE5EBQROBETETkQFBE4ETgROBEUEAANBQ==",
      "AC_On": "JgDYAAABJpUSNxE5EBQRExETERMRORA5ETgROBE5EDkROBETERQQORETERMRExEUEBQROBE4ETkQFBETERMRExETERQQFBETERMRExEUEBQRExE4ETgRFBETERMRExETERQQFBETERMRExEUEBQRExETETgRFBAUERMROBE4ERQQFBE4ERMRExEUEBQRExE4ERMRFBA5ERMRExETERQQFBETETgRExEUEBQRExETERMRFBAUERMRExE4ERQQORETERMRExE5EBQROBETETkQFBA5ERMRExE5EAANBQ==",
      "AC_Cool": "JgDYAAABJZYROBE4ERMRFBAUERMROBE4ETkROBE4ETkQORETERMROBEUEBQRExETERMRORA5ETgRExEUEBQQFBETERMRExEUEBQRExETERMRFBA5ETgRExETERQQFBETERMRExEUEBQRExETERMRExEUEDkRExETERMRORE4ERMRExE5EBQRExETERMRFBA5ERMRExE4ERQQFBETERMRExEUEDkRExETERMRFBAUERMRExETERMRFBAUETgROBEUEBQQFBE4ERMRFBA5ETgRExE4ERQQFBE4EQANBQ==",
      "AC_Speed": "JgDYAAABJZYROBE4ERMRFBAUERMROBE5EDkROBE4ETkQORETERMROBEUEBQRExETERMRORA5ETgRExEUEBQRExETERMRExEUEBQRExETERMRFBAUETgRExETERQQFBETERMRExEUEBQQFBETERMRExEUEDkRExETERMRORA5ERMRExE5EBQRExETERMRExE5ERMRExE4ERQQFBETERMRExETETkQFBETERMRExEUEBQRExETERMRFBAUERMROBETERQQFBE4ERMRExEUEDkRExE4ETkQORETEQANBQ==",
      "AC_Timer": "JgDYAAABJpUSNxE5ERMRExETERMRORE4EjcSNxI4ETgROBETERQQORETERMRExEUEBQROBE4EjgQFBETERMRExEUEBQQFBISERMRExEUEBQRExE4EjgQFBAUETgROBE5EDkRExETEhIRFBETERMRExETETkQFBETERMROBE5ERMRExE4EhMRExETERMSEhE5EBQRExE4ERMRFBAUERMSEhISETkROBETEhIRExEUEBQRExETERMRFBE4ERMROBE5EBQRExE4ERMRORA5ERMROBE5ETgROBI3EgANBQ==",
      "AC_Mode": "JgDYAAABJpURORE4ERMRExETERQQORE4ETgRORE4ERMSEhISEhMQORETERMRExITEBQROBE4ETkQFBETEhIRExITEBQRExISERMRExITEBQRExE4ETkQFBAUERMRExETERQQFBETERMRExEUERMRExETERMRORAUERMROBE4EhMQFBE4EhIRFBETEBQRExE4ERQQFBA5ERMRExITEBQRExETETgRFBAUERMRExISERMRFBETERMSEhISETkQORETERMRFBA5ERMRExE4EjgQORE4ERMRFBA5EQANBQ==",
      "AC_Left_Right": "JgDYAAABJpUSOBA5EhISEhETERQQORE4EjcRORA5EjcROBEUERMROBETERMSExAUERMRExETERQQFBETERMRExETERQRExISERMRExEUEBQRExE4ETkQFBETERMSEhISERQQFBETERMRExITEBQRExISETgRFBAUERMROBI3EhMRExI3ERMRFBETERMRExE4ERQQFBE4EhISEhEUEBQRExETEjcSExAUERMRExETERQQFBETERMRExE5ETgRExETEhIRFBE4ERMSNxE4ERQRExE4ETgSExA5EQANBQ==",
      "AC_Up_Down": "JgDYAAABJZUSOBA5EhIRExETEhMQORI3ERMRFBAUETgROBETERQQORETERMRExEUEBQROBI3ETkQFBETERMRExEUEBQRExETERMSExAUERMRExE4ETkQFBETERMRExISERQRExETEhIRExEUERMRExETETgRFBAUERMROBE4ERQRExE4ERMRFBAUERMRExE4ERQQFBE4ERMRExEUEBQRExETETgRFBAUERMRExETERQQFBETERMRExETETkQFBETERMRExE5ERMROBE4ERQQORETERMRExE5EAANBQ==",
      "AC_Temp_Up": "JgDYAAABJZYROBI3EhMQFBAUERMROBE5EDkROBE4ERQQFBE4ERMROBEUERMRExETEhIRORA5EjcSEhEUEBQRExETERMRFBAUERMSEhETEhMQFBE4EjcSEhEUEBQRExETERMRFBAUERMRExETERMSExETETgSEhEUEBQROBE4EhIRFBA5ERMRExETERQQFBE4EhIRExE5EBQRExETERMSExAUETgRExEUEBQQFBETERMRExEUEBQRExETERMRFBAUERMRExE4EhMQFBETERMROBE5EBQRExE4EgANBQ==",
      "AC_Temp_Down": "JgDYAAABJZYROBE4EhIRFBETEBQROBI3ETkQORI3EjgROBETERMROBITERMRExISERMRORA5ETgRExEUEBQRExISERMRExEUEBQSEhETERMRFBA5ETgRExEUEBQRExETEhIRFBAUEBQSEhETEhIRFBAUETgSEhETERQQORE4EhIRFBA5ERMRExETERQRExE4EhIRExI4ERMRExETERMSExAUETgRExISERQQFBETEhISEhEUEBQRExE4ERMSExAUERMSEhI3ERQQORETERMRExI4EBQSEhE4EgANBQ=="
    },
    "Fan in bedroom": {
      "Fan_On": "JgBQAAABKpMTExMSExITEhMSExITExITEzcROBI4EzcSOBI4EjgTNxI4EhMTNxITExMSExM3ERQTEhM3EhMTNxI4EjgSExM3EwAFJQABKEoTAA0FAAAAAAAAAAA=",
      "Fan_Off": "JgBQAAABJ5QTEhMSExMSExITExITEhMSEzcSOBI4EjgSOBI4EjgSOBI4ERQTNxITExITEhM3EhMTExI3EhQTNxE5ETgSFBM3EQAFJwABKEoSAA0FAAAAAAAAAAA=",
      "Fan_Speed": "JgBQAAABKJQTEhITEhMSExITEhMSFBEUETkROBM3EzcTNxI4EjgTNxM3EjgTNxITExISExM3EhMTEhITExISOBI4EjgTExE4EwAFJgABKEsSAA0FAAAAAAAAAAA=",
      "Fan_Timer": "JgBQAAABKZQTEhMSEhMTExITExITEhMSEzcSOBI4ETkSOBI4ETgSOBI4EjgTNxITExITExITExITEhMSExITNxI4EjgRORE5EQAFJwABKEkSAA0FAAAAAAAAAAA=",
      "Fan_Swing": "JgBQAAABJ5USExMSExITEhMSExMSExITEzcRORI3EjgSOBI4EjgSOBI4EhMTEhM3EhMTEhMTEhMSExI4EjgRFBM3ETkRORE4EgAFJwABKEoTAA0FAAAAAAAAAAA="
    }
  }
}
```

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

