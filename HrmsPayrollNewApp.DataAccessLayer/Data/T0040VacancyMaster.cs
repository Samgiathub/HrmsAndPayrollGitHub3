using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040VacancyMaster
{
    public decimal VacancyId { get; set; }

    public string VacancyName { get; set; } = null!;

    public decimal CmpId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0010HrCompReq> T0010HrCompReqs { get; set; } = new List<T0010HrCompReq>();
}
