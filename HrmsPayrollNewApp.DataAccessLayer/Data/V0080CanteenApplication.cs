using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080CanteenApplication
{
    public decimal AppId { get; set; }

    public string? AppNo { get; set; }

    public string? ReceiveDate { get; set; }

    public string EmpName { get; set; } = null!;

    public string DesigName { get; set; } = null!;

    public string DeptName { get; set; } = null!;

    public decimal EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public string? CntId { get; set; }

    public int? Duration { get; set; }

    public string? CanteenName { get; set; }

    public string? Canteen { get; set; }

    public string? CntName { get; set; }

    public string? DurationName { get; set; }

    public string? DateDuration { get; set; }

    public string? Description { get; set; }

    public string? FromDate { get; set; }

    public string? ToDate { get; set; }

    public string? AppType { get; set; }

    public string? GuestType { get; set; }

    public string? GuestName { get; set; }

    public int? GuestCount { get; set; }

    public int? TotalCount { get; set; }
}
