using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ProjectMaster
{
    public decimal PrjId { get; set; }

    public string PrjName { get; set; } = null!;

    public decimal CmpId { get; set; }

    public string? PrjGroup { get; set; }

    public decimal? PrjPrice { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0090EmpContractDetail> T0090EmpContractDetails { get; set; } = new List<T0090EmpContractDetail>();

    public virtual ICollection<T0100ProjectAllocation> T0100ProjectAllocations { get; set; } = new List<T0100ProjectAllocation>();

    public virtual ICollection<T0150EmpWorkDetail> T0150EmpWorkDetails { get; set; } = new List<T0150EmpWorkDetail>();
}
