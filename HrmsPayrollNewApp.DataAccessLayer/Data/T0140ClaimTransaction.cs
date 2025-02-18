using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140ClaimTransaction
{
    public decimal ClaimTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ClaimId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal ClaimOpening { get; set; }

    public decimal ClaimIssue { get; set; }

    public decimal ClaimReturn { get; set; }

    public decimal ClaimClosing { get; set; }

    public int? SalaryTranId { get; set; }

    public virtual T0040ClaimMaster Claim { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
