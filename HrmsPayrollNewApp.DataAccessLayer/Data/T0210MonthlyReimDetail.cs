using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210MonthlyReimDetail
{
    public decimal AdReimTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? RcId { get; set; }

    public decimal? RcAprId { get; set; }

    public decimal? TempSalTranId { get; set; }

    public decimal? SalTranId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? Amount { get; set; }

    public decimal Taxable { get; set; }

    public decimal TaxFreeAmount { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0120RcApproval? RcApr { get; set; }
}
