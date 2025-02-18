using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080CanteenApplicationBackupBhavesh24042023
{
    public decimal AppId { get; set; }

    public string? AppNo { get; set; }

    public string? ReceiveDate { get; set; }

    public string? EmpName { get; set; }

    public string DesigName { get; set; } = null!;

    public string DeptName { get; set; } = null!;

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public string? Food { get; set; }

    public int? Duration { get; set; }

    public string? CanteenName { get; set; }

    public string? Canteen { get; set; }

    public string? FoodName { get; set; }

    public string? DurationName { get; set; }
}
