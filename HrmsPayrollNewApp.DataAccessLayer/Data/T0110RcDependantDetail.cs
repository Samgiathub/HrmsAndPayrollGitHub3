using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110RcDependantDetail
{
    public decimal RcDependentId { get; set; }

    public decimal RcAppId { get; set; }

    public decimal RcId { get; set; }

    public decimal CmpId { get; set; }

    public string? Name { get; set; }

    public string? Relation { get; set; }

    public decimal? Age { get; set; }

    public string? BillNo { get; set; }

    public DateTime? BillDate { get; set; }

    public string? PrescribeBy { get; set; }

    public decimal? Amount { get; set; }

    public decimal AprAmount { get; set; }

    public decimal? AdExpMasterId { get; set; }

    public DateTime? ExpFromDate { get; set; }

    public DateTime? ExpToDate { get; set; }

    public virtual T0050AdExpenseLimitMaster? AdExpMaster { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0050AdMaster Rc { get; set; } = null!;

    public virtual T0100RcApplication RcApp { get; set; } = null!;
}
