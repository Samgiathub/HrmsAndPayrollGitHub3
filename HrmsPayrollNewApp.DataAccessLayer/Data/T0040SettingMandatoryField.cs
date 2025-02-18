using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040SettingMandatoryField
{
    public decimal? TranId { get; set; }

    public decimal? CmpId { get; set; }

    public string? ModuleName { get; set; }

    public string? FieldsName { get; set; }

    public bool? IsMandatory { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public string? IpAddress { get; set; }

    public string? ControlDisplayName { get; set; }

    public string? DbControlId { get; set; }
}
