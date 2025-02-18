using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050CfEmpTypeDetail
{
    public decimal SettingId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? LeaveId { get; set; }

    public decimal? CfTypeId { get; set; }

    public decimal? ResetMonths { get; set; }

    public string Duration { get; set; } = null!;

    public string? CfMonths { get; set; }

    public decimal? ReleaseMonth { get; set; }

    public string? ResetMonthString { get; set; }

    public byte? LapsAfterRelease { get; set; }
}
