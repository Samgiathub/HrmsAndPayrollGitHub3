using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080GrievAppAdminSide
{
    public decimal GaId { get; set; }

    public string? AppNo { get; set; }

    public string? ReceiveDate { get; set; }

    public string? From { get; set; }

    public string? NameFrom { get; set; }

    public string? RFrom { get; set; }

    public string? GrievAgainst { get; set; }

    public string? NameAgainst { get; set; }

    public string? SubjectLine { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? RDate { get; set; }

    public string? DocumentName { get; set; }

    public string? ApplicationStatus { get; set; }

    public decimal? EmpIdf { get; set; }

    public string? BranchApp { get; set; }

    public decimal? BId { get; set; }

    public decimal EmpIdt { get; set; }

    public string? Details { get; set; }

    public string EmailT { get; set; } = null!;

    public string AddressT { get; set; } = null!;

    public string ContactT { get; set; } = null!;
}
