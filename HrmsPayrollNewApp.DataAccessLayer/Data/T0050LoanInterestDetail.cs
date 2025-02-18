using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050LoanInterestDetail
{
    public decimal TransId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? LoanId { get; set; }

    public decimal? StandardRates { get; set; }

    public DateTime? EffectiveDate { get; set; }
}
