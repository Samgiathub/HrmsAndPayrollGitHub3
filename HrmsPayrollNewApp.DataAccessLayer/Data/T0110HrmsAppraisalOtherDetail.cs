using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110HrmsAppraisalOtherDetail
{
    public decimal HaoId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal InitiateId { get; set; }

    public decimal? AoId { get; set; }

    public string? Justification { get; set; }

    public int? TimeFrameId { get; set; }

    public decimal? PromoDesig { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? ApprovalLevel { get; set; }

    public int? IsApplicable { get; set; }
}
