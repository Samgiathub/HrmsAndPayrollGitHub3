using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0060GpfInterestRate
{
    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal AdId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public decimal InterestRate { get; set; }

    public DateTime? SystemDate { get; set; }
}
