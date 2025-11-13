ips_toolbox_set_results
=======================

Role used to provide an output in JSON for other roles.

Version
-------

2.1


Requirements
------------

none

Synopsis
--------

documentation [here](https://socialbusiness.group.echonet/communities/service/html/communityview?communityUuid=d591fc87-7ec1-4c31-bcf6-a2782259c942#fullpageWidgetId=W6ba1b47da222_4de2_af01_0ed00e2952bb&file=23a847f6-a78b-4723-a9f0-e1d6a7b36b8e).

<br>


Parameters
----------

**Parameter**  | **Choices/`Default`**                  | ***Comments***
-------------- | -------------------------------------- | --------
set_results_state | `"undefined"` | set the state according to the documentation
set_results_item | `"undefined"` | set the item according to the documentation
set_results_value | `"undefined"` | set the value according to the documentation
set_results_component | `"undefined"` | set the component according to the documentation
set_results_status | `"undefined"` | set the status according to the documentation
set_results_operation | `"undefined"` | set the operation according to the documentation
set_results_result_name | `"result"` | set the name of the resulted fact according to the documentation
set_results_script_mode | `false` | when true, does not aggregate the results fact

Return Values
-------------

**key** | **Description**
------- | ------------ 
Component | Name of the component used
Date | Date of the run
Item | Item targeted by the operation
Operation | Operation performed during the run
State | State of the operation
Status | Status of the run
Target | Target of the operation
User | User who performed the action
Value | Json informations for specifics  



License
-------

BSD


