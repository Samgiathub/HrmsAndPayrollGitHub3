using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TaxLimit
{
    public decimal ItLId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public string Gender { get; set; } = null!;

    public decimal FromLimit { get; set; }

    public decimal ToLimit { get; set; }

    public decimal Percentage { get; set; }

    public decimal AdditionalAmount { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }

    public string? Regime { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0011Login? Login { get; set; }
}
