using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050UniformMasterDetail
{
    public decimal? CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal UniId { get; set; }

    public string? UniName { get; set; }

    public DateTime? UniEffectiveDate { get; set; }

    public decimal? UniRate { get; set; }

    public decimal? UniDeductInstallment { get; set; }

    public decimal? UniRefundInstallment { get; set; }
}
