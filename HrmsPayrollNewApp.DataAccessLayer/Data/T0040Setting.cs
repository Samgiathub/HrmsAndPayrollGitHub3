using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040Setting
{
    public decimal SettingId { get; set; }

    public decimal CmpId { get; set; }

    public string SettingName { get; set; } = null!;

    public string SettingValue { get; set; } = null!;

    public string? Comment { get; set; }

    public string? GroupBy { get; set; }

    public string? Alias { get; set; }

    public string? ModuleName { get; set; }

    public byte? ValueType { get; set; }

    public string? ValueRef { get; set; }
}
