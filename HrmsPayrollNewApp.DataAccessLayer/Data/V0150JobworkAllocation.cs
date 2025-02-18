using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0150JobworkAllocation
{
    public string? AgencyName { get; set; }

    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AgencyId { get; set; }

    public decimal PrjId { get; set; }

    public decimal WorkId { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public string? WorkDetail { get; set; }

    public DateTime? SubmitDate { get; set; }

    public string PrjStatus { get; set; } = null!;

    public string? Remark { get; set; }

    public string? PrjName { get; set; }

    public string? WorkName { get; set; }
}
