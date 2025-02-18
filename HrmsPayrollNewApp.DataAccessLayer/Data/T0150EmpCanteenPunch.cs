using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0150EmpCanteenPunch
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime CanteenPunchDatetime { get; set; }

    public string? Flag { get; set; }

    public string DeviceIp { get; set; } = null!;

    public string? Reason { get; set; }

    public decimal UserId { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal? CanteenId { get; set; }

    public string? CardNo { get; set; }

    public decimal? Quantity { get; set; }

    public decimal? CanteenTransactionId { get; set; }

    public DateTime TransFinishDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
