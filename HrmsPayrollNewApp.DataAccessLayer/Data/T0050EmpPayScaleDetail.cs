using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050EmpPayScaleDetail
{
    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public decimal PayScaleId { get; set; }

    public DateTime? SystemDate { get; set; }
}
