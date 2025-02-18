using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0030CategoryMaster
{
    public decimal CatId { get; set; }

    public decimal CmpId { get; set; }

    public string CatName { get; set; } = null!;

    public string? CatDescription { get; set; }

    public string? CateCode { get; set; }

    public decimal ChkBirth { get; set; }

    public byte NewJoinEmployee { get; set; }

    public decimal OtRate11pm { get; set; }

    public byte? IsActive { get; set; }

    public DateTime? InActiveEffeDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0040GradeMaster> T0040GradeMasters { get; set; } = new List<T0040GradeMaster>();

    public virtual ICollection<T0040KpiMaster> T0040KpiMasters { get; set; } = new List<T0040KpiMaster>();

    public virtual ICollection<T0080EmpMaster> T0080EmpMasters { get; set; } = new List<T0080EmpMaster>();
}
