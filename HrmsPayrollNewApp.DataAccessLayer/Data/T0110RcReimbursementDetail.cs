using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110RcReimbursementDetail
{
    public decimal RcReimId { get; set; }

    public decimal RcAppId { get; set; }

    public decimal EmpId { get; set; }

    public decimal RcId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime BillDate { get; set; }

    public string? BillNo { get; set; }

    public decimal? Amount { get; set; }

    public string? Description { get; set; }

    public string? Comments { get; set; }

    public decimal AprAmount { get; set; }

    public decimal? AdExpMasterId { get; set; }

    public DateTime? ExpFromDate { get; set; }

    public DateTime? ExpToDate { get; set; }

    public virtual T0050AdExpenseLimitMaster? AdExpMaster { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0050AdMaster Rc { get; set; } = null!;

    public virtual T0100RcApplication RcApp { get; set; } = null!;
}
