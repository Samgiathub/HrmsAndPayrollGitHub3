using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0045ClaimFnfDeductionSlab
{
    public decimal ClaimFnfId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ClaimId { get; set; }

    public decimal NoOfYear { get; set; }

    public decimal DeduInPer { get; set; }

    public DateTime EffectiveDate { get; set; }
}
