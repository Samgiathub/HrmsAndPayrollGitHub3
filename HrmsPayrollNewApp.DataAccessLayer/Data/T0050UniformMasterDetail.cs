using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050UniformMasterDetail
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? UniId { get; set; }

    public DateTime? UniEffectiveDate { get; set; }

    public decimal? UniRate { get; set; }

    public decimal? UniDeductInstallment { get; set; }

    public decimal? UniRefundInstallment { get; set; }

    public string? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public string? IpAddress { get; set; }
}
