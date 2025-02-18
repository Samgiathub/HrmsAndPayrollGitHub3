using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100AdvancePayment
{
    public decimal AdvId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal AdvAmount { get; set; }

    public decimal AdvPDays { get; set; }

    public decimal AdvApproxSalary { get; set; }

    public string AdvComments { get; set; } = null!;

    public decimal? ResId { get; set; }

    public decimal? AdvApprovalId { get; set; }

    public decimal? SalTranId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
