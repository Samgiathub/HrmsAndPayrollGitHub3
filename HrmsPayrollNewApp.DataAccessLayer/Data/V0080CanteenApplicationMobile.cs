using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080CanteenApplicationMobile
{
    public decimal AppId { get; set; }

    public string? AppNo { get; set; }

    public DateTime? ReceiveDate { get; set; }

    public string? EmpName { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? DeptId { get; set; }

    public string Food { get; set; } = null!;

    public int Duration { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public string CanteenName { get; set; } = null!;

    public string? Description { get; set; }

    public string? AppType { get; set; }

    public int GuestTypeId { get; set; }

    public string GuestName { get; set; } = null!;

    public int GuestCount { get; set; }

    public string? CntName { get; set; }

    public string FdName { get; set; } = null!;

    public string? FromTime { get; set; }

    public string? ToTime { get; set; }

    public string? GuestTypeName { get; set; }
}
