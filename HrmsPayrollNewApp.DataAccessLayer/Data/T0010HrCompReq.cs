using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0010HrCompReq
{
    public decimal CmpReqId { get; set; }

    public decimal VacancyId { get; set; }

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

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040DesignationMaster Desig { get; set; } = null!;

    public virtual T0040QualificationMaster Qual { get; set; } = null!;

    public virtual T0040TypeMaster Type { get; set; } = null!;

    public virtual T0040VacancyMaster Vacancy { get; set; } = null!;
}
