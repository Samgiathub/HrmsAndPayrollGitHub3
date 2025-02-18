using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040SpecialityMaster
{
    public decimal SpecialityId { get; set; }

    public decimal? CmpId { get; set; }

    public string? SpecialityName { get; set; }

    public string? Description { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual ICollection<T0040TsProjectMaster> T0040TsProjectMasters { get; set; } = new List<T0040TsProjectMaster>();
}
