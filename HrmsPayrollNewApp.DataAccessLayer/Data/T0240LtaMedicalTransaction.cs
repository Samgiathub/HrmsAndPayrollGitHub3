using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0240LtaMedicalTransaction
{
    public decimal LmTranId { get; set; }

    public decimal CmpId { get; set; }

    public int TypeId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? BalanceOpening { get; set; }

    public decimal? BalanceCrediated { get; set; }

    public decimal? BalanceUsed { get; set; }

    public decimal? BalanceClosing { get; set; }

    public decimal? SalTranId { get; set; }

    public decimal? LmAprId { get; set; }

    public decimal? PStatus { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
