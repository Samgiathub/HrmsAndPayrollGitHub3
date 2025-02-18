using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090AdvancePaymentApproval
{
    public decimal AdvApprovalId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime? ApplicationDate { get; set; }

    public decimal RequestedAmount { get; set; }

    public string EmpRemarks { get; set; } = null!;

    public DateTime? ApprovalDate { get; set; }

    public decimal? ApprovalAmount { get; set; }

    public string? SuperiorRemarks { get; set; }

    public string AdvanceStatus { get; set; } = null!;

    public decimal? ApprovedBy { get; set; }

    public DateTime CreateDate { get; set; }

    public decimal? ResId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
