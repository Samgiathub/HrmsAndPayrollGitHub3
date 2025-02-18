using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040EmpEsopAllocation
{
    public decimal EsopId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public int? NoOfShare { get; set; }

    public decimal? PerquisiteValue { get; set; }

    public decimal? TaxablePerqValue { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpPrice { get; set; }
}
