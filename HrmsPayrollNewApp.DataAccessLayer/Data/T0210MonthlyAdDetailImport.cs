using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210MonthlyAdDetailImport
{
    public decimal ITranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AdId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal IAdAmount { get; set; }

    public string IAdComments { get; set; } = null!;

    public decimal IAdMaxLimit { get; set; }

    public byte IsNotExists { get; set; }

    public virtual T0050AdMaster Ad { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
