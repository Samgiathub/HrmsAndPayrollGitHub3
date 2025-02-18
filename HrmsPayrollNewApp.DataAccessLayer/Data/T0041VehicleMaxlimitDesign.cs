using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0041VehicleMaxlimitDesign
{
    public decimal TranId { get; set; }

    public int VehicleId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? GradeId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal MaxLimit { get; set; }

    public double EmployeeContribution { get; set; }

    public virtual T0040DesignationMaster? Desig { get; set; }

    public virtual T0040VehicleTypeMaster Vehicle { get; set; } = null!;
}
