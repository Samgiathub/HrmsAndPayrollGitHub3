using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V9999AxMapping
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public string HeadName { get; set; } = null!;

    public string Account { get; set; } = null!;

    public string Narration { get; set; } = null!;

    public byte MonthYear { get; set; }

    public DateTime? LastUpdated { get; set; }

    public decimal AdId { get; set; }

    public decimal SortingNo { get; set; }

    public string Type { get; set; } = null!;

    public decimal LoanId { get; set; }

    public string? VenderCode { get; set; }

    public decimal BankId { get; set; }

    public string OtherAccount { get; set; } = null!;

    public decimal ClaimId { get; set; }

    public byte IsHighlight { get; set; }

    public string? BackColor { get; set; }

    public string? ForeColor { get; set; }

    public decimal? CenterId { get; set; }

    public decimal? SegmentId { get; set; }

    public string? CenterName { get; set; }

    public decimal BandId { get; set; }
}
