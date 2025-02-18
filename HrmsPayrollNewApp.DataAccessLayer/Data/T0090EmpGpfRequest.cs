using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpGpfRequest
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AdId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public decimal Amount { get; set; }

    public DateTime? SystemDate { get; set; }
}
