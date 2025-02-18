using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080GrievAppAdminSide2
{
    public decimal GaId { get; set; }

    public string? AppNo { get; set; }

    public DateTime? ReceiveDate { get; set; }

    public decimal? From { get; set; }

    public decimal EmpIdf { get; set; }

    public string NameF { get; set; } = null!;

    public string AddressF { get; set; } = null!;

    public string EmailF { get; set; } = null!;

    public string ContactF { get; set; } = null!;

    public decimal? ReceiveFrom { get; set; }

    public decimal? GrievAgainst { get; set; }

    public decimal EmpIdt { get; set; }

    public string NameT { get; set; } = null!;

    public string AddressT { get; set; } = null!;

    public string EmailT { get; set; } = null!;

    public string ContactT { get; set; } = null!;

    public string? SubjectLine { get; set; }

    public string? Details { get; set; }

    public string? DocumentName { get; set; }

    public decimal? CmpId { get; set; }
}
