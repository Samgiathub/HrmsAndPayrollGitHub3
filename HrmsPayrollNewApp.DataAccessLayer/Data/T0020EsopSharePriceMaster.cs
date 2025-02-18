using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0020EsopSharePriceMaster
{
    public decimal TranId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? MarketPrice { get; set; }

    public decimal? EmployeePrice { get; set; }

    public decimal? MonthWiseLockingPeriod { get; set; }

    public DateTime? CreatedDate { get; set; }

    public int? CmpId { get; set; }
}
