using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0190MonthlyAdDetailImport
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AdId { get; set; }

    public int Month { get; set; }

    public int Year { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? Amount { get; set; }

    public string Comments { get; set; } = null!;

    public byte? IsNotExists { get; set; }

    public decimal IncrementId { get; set; }

    public virtual T0050AdMaster Ad { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
