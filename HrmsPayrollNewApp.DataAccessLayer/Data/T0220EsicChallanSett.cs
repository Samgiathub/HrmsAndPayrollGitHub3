using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0220EsicChallanSett
{
    public decimal EsicChallanId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal BankId { get; set; }

    public decimal Month { get; set; }

    public decimal Year { get; set; }

    public DateTime PaymentDate { get; set; }

    public string ECode { get; set; } = null!;

    public string AccGrNo { get; set; } = null!;

    public string PaymentMode { get; set; } = null!;

    public string ChequeNo { get; set; } = null!;

    public decimal TotalSubScriber { get; set; }

    public decimal TotalWagesDue { get; set; }

    public decimal EmpContPer { get; set; }

    public decimal EmployerContPer { get; set; }

    public decimal EmpContAmount { get; set; }

    public decimal EmployerContAmount { get; set; }

    public decimal TotalAmount { get; set; }

    public virtual T0040BankMaster Bank { get; set; } = null!;

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
