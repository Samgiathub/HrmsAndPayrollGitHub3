using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0150JobworkAllocationReport
{
    public string AgencyName { get; set; } = null!;

    public decimal AgencyId { get; set; }

    public decimal PrjId { get; set; }

    public string PrjName { get; set; } = null!;

    public decimal WorkId { get; set; }

    public string WorkName { get; set; } = null!;

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public string? WorkDetail { get; set; }

    public DateTime? SubmitDate { get; set; }

    public string? Remark { get; set; }

    public decimal CmpId { get; set; }

    public string CmpName { get; set; } = null!;

    public string CmpAddress { get; set; } = null!;

    public string PrjStatus { get; set; } = null!;

    public string? AgencyAddress { get; set; }

    public string? AgencyCity { get; set; }

    public string AgencyPhone { get; set; } = null!;
}
