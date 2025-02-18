using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095ItEmpTaxRegime
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public string FinancialYear { get; set; } = null!;

    public string Regime { get; set; } = null!;

    public decimal? UserId { get; set; }

    public DateTime? SystemDate { get; set; }

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
