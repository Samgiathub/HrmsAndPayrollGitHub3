using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095AuthorizedSignature
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal BranchId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public DateTime SystemDate { get; set; }
}
