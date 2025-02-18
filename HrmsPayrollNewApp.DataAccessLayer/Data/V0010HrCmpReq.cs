using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0010HrCmpReq
{
    public decimal VacancyId { get; set; }

    public decimal CmpReqId { get; set; }

    public decimal? Experience { get; set; }

    public string JobDesc { get; set; } = null!;

    public decimal QualId { get; set; }

    public decimal TypeId { get; set; }

    public decimal DesigId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LocId { get; set; }

    public DateTime PostedDate { get; set; }

    public string Email { get; set; } = null!;

    public string ContactName { get; set; } = null!;

    public string City { get; set; } = null!;

    public string VacancyCode { get; set; } = null!;

    public string QualName { get; set; } = null!;

    public string? LocName { get; set; }

    public string VacancyName { get; set; } = null!;
}
