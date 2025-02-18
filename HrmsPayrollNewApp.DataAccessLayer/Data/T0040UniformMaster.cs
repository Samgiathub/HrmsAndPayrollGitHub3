using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040UniformMaster
{
    public decimal UniId { get; set; }

    public decimal? CmpId { get; set; }

    public string? UniName { get; set; }

    public virtual ICollection<T0090UniformRequisitionApplication> T0090UniformRequisitionApplications { get; set; } = new List<T0090UniformRequisitionApplication>();
}
