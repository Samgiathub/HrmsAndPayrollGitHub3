using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080GrievApplication
{
    public decimal GaId { get; set; }

    public DateTime? ReceiveDate { get; set; }

    public decimal? From { get; set; }

    public decimal? EmpIdf { get; set; }

    public string? NameF { get; set; }

    public string? AddressF { get; set; }

    public string? EmailF { get; set; }

    public string? ContactF { get; set; }

    public decimal? ReceiveFrom { get; set; }

    public decimal? GrievAgainst { get; set; }

    public decimal? EmpIdt { get; set; }

    public string? NameT { get; set; }

    public string? AddressT { get; set; }

    public string? EmailT { get; set; }

    public string? ContactT { get; set; }

    public string? SubjectLine { get; set; }

    public string? Details { get; set; }

    public string? DocumentName { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? UpdatedDate { get; set; }

    public string? UserId { get; set; }

    public int? IsForwarded { get; set; }

    public string? AppNo { get; set; }
}
