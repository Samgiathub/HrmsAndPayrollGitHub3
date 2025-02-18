using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080CanteenApplication
{
    public decimal AppId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? ReceiveDate { get; set; }

    public decimal? EmpId { get; set; }

    public string? EmpName { get; set; }

    public string? Designation { get; set; }

    public string? Department { get; set; }

    public string? CntId { get; set; }

    public int? Duration { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? CanteenName { get; set; }

    public string? AppNo { get; set; }

    public int? UserId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? DeptId { get; set; }

    public string? Description { get; set; }

    public string? AppType { get; set; }

    public int? GuestTypeId { get; set; }

    public string? GuestName { get; set; }

    public int? GuestCount { get; set; }
}
