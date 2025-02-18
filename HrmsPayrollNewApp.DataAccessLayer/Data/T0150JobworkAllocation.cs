using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0150JobworkAllocation
{
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

    public virtual T0030AgencyMaster Agency { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040ProjectMaster Prj { get; set; } = null!;

    public virtual T0040WorkMaster Work { get; set; } = null!;
}
