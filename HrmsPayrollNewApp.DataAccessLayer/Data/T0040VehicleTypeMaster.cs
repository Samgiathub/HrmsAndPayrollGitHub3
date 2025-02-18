using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040VehicleTypeMaster
{
    public int VehicleId { get; set; }

    public decimal CmpId { get; set; }

    public string? VehicleType { get; set; }

    public double? VehicleMaxLimit { get; set; }

    public byte? DesigWiseLimit { get; set; }

    public byte? GradeWiseLimit { get; set; }

    public byte? BranchWiseLimit { get; set; }

    public bool? AttachMandatory { get; set; }

    public byte? VehicleAllowBeyondLimit { get; set; }

    public int? NoOfYearLimit { get; set; }

    public int EligibleJoiningMonths { get; set; }

    public double DeductionPercentage { get; set; }

    public virtual ICollection<T0041VehicleMaxlimitDesign> T0041VehicleMaxlimitDesigns { get; set; } = new List<T0041VehicleMaxlimitDesign>();

    public virtual ICollection<T0100VehicleApplication> T0100VehicleApplications { get; set; } = new List<T0100VehicleApplication>();

    public virtual ICollection<T0110VehicleRegistrationDetail> T0110VehicleRegistrationDetails { get; set; } = new List<T0110VehicleRegistrationDetail>();
}
