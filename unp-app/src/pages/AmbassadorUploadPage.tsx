import React, { useState } from 'react';
import { ArrowLeft, Plus, Trash2, Upload, CheckCircle } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { FeatureGate } from '../components/FeatureGate';

export const AmbassadorUploadPage: React.FC = () => {
  const navigate = useNavigate();
  const [submitted, setSubmitted] = useState(false);
  const [form, setForm] = useState({
    name: '',
    category: 'cocktail',
    description: '',
    ingredients: [{ name: '', amount: '' }],
    instructions: [''],
    tags: '',
  });

  const updateField = (field: string, value: string) =>
    setForm(f => ({ ...f, [field]: value }));

  const addIngredient = () =>
    setForm(f => ({ ...f, ingredients: [...f.ingredients, { name: '', amount: '' }] }));

  const removeIngredient = (i: number) =>
    setForm(f => ({ ...f, ingredients: f.ingredients.filter((_, idx) => idx !== i) }));

  const updateIngredient = (i: number, field: 'name' | 'amount', val: string) =>
    setForm(f => ({
      ...f,
      ingredients: f.ingredients.map((ing, idx) => idx === i ? { ...ing, [field]: val } : ing),
    }));

  const addStep = () => setForm(f => ({ ...f, instructions: [...f.instructions, ''] }));
  const removeStep = (i: number) => setForm(f => ({ ...f, instructions: f.instructions.filter((_, idx) => idx !== i) }));
  const updateStep = (i: number, val: string) =>
    setForm(f => ({ ...f, instructions: f.instructions.map((s, idx) => idx === i ? val : s) }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitted(true);
    setTimeout(() => navigate('/pour'), 2500);
  };

  if (submitted) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen px-4 text-center gap-4">
        <div className="w-16 h-16 rounded-full bg-green-500/20 border border-green-500/30 flex items-center justify-center">
          <CheckCircle size={28} className="text-green-400" />
        </div>
        <h2 className="text-white font-bold text-xl">Recipe Submitted!</h2>
        <p className="text-gray-400 text-sm max-w-xs">Your recipe is under review. It will appear in Pour once approved. Redirecting...</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen px-4 pt-6 pb-10">
      <div className="flex items-center gap-3 mb-6">
        <Link to="/pour" className="w-9 h-9 rounded-full bg-white/5 border border-white/10 flex items-center justify-center">
          <ArrowLeft size={16} className="text-white" />
        </Link>
        <div>
          <h1 className="text-xl font-bold text-white">Upload Recipe</h1>
          <p className="text-gray-400 text-xs">Ambassador submission</p>
        </div>
      </div>

      <FeatureGate
        requiredRole="ambassador"
        label="Ambassador Feature"
        description="Only verified Beverage Ambassadors can upload recipes. Apply from your Profile."
      >
        <form onSubmit={handleSubmit} className="flex flex-col gap-5">
          {/* Basic info */}
          <section className="flex flex-col gap-3">
            <h2 className="text-white font-semibold text-sm uppercase tracking-wider">Basic Info</h2>
            <input
              type="text"
              placeholder="Recipe name *"
              value={form.name}
              onChange={e => updateField('name', e.target.value)}
              required
              className="w-full bg-[#1A1628] border border-white/10 rounded-xl px-4 py-3 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-amber-500/50"
            />
            <select
              value={form.category}
              onChange={e => updateField('category', e.target.value)}
              className="w-full bg-[#1A1628] border border-white/10 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-amber-500/50"
            >
              {['cocktail', 'mocktail', 'wine', 'spirit', 'beer', 'shot'].map(c => (
                <option key={c} value={c} className="bg-[#1A1628]">{c.charAt(0).toUpperCase() + c.slice(1)}</option>
              ))}
            </select>
            <textarea
              placeholder="Description *"
              value={form.description}
              onChange={e => updateField('description', e.target.value)}
              required
              rows={3}
              className="w-full bg-[#1A1628] border border-white/10 rounded-xl px-4 py-3 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-amber-500/50 resize-none"
            />
            <input
              type="text"
              placeholder="Tags (comma separated, e.g. smoky, spicy, nightlife)"
              value={form.tags}
              onChange={e => updateField('tags', e.target.value)}
              className="w-full bg-[#1A1628] border border-white/10 rounded-xl px-4 py-3 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-amber-500/50"
            />
          </section>

          {/* Photo/video upload */}
          <section>
            <h2 className="text-white font-semibold text-sm uppercase tracking-wider mb-3">Media</h2>
            <div className="border border-dashed border-white/20 rounded-xl p-6 flex flex-col items-center gap-3 text-center">
              <Upload size={24} className="text-gray-500" />
              <p className="text-gray-400 text-sm">Drag & drop photo or video</p>
              <button type="button" className="px-4 py-2 rounded-full border border-white/20 text-gray-300 text-xs hover:border-white/40 transition-colors">
                Browse Files
              </button>
              <p className="text-gray-600 text-xs">JPG, PNG, MP4 up to 50MB</p>
            </div>
          </section>

          {/* Ingredients */}
          <section>
            <div className="flex items-center justify-between mb-3">
              <h2 className="text-white font-semibold text-sm uppercase tracking-wider">Ingredients</h2>
              <button type="button" onClick={addIngredient} className="flex items-center gap-1 text-amber-400 text-xs">
                <Plus size={12} /> Add
              </button>
            </div>
            <div className="flex flex-col gap-2">
              {form.ingredients.map((ing, i) => (
                <div key={i} className="flex gap-2">
                  <input
                    type="text"
                    placeholder="Ingredient"
                    value={ing.name}
                    onChange={e => updateIngredient(i, 'name', e.target.value)}
                    className="flex-1 bg-[#1A1628] border border-white/10 rounded-xl px-3 py-2.5 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-amber-500/50"
                  />
                  <input
                    type="text"
                    placeholder="Amount"
                    value={ing.amount}
                    onChange={e => updateIngredient(i, 'amount', e.target.value)}
                    className="w-24 bg-[#1A1628] border border-white/10 rounded-xl px-3 py-2.5 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-amber-500/50"
                  />
                  {form.ingredients.length > 1 && (
                    <button type="button" onClick={() => removeIngredient(i)} className="text-red-400 hover:text-red-300 p-1">
                      <Trash2 size={14} />
                    </button>
                  )}
                </div>
              ))}
            </div>
          </section>

          {/* Instructions */}
          <section>
            <div className="flex items-center justify-between mb-3">
              <h2 className="text-white font-semibold text-sm uppercase tracking-wider">Instructions</h2>
              <button type="button" onClick={addStep} className="flex items-center gap-1 text-amber-400 text-xs">
                <Plus size={12} /> Add step
              </button>
            </div>
            <div className="flex flex-col gap-2">
              {form.instructions.map((step, i) => (
                <div key={i} className="flex gap-2">
                  <span className="w-6 h-6 rounded-full bg-amber-500/20 text-amber-400 text-xs flex items-center justify-center shrink-0 mt-3">{i + 1}</span>
                  <textarea
                    placeholder={`Step ${i + 1}`}
                    value={step}
                    onChange={e => updateStep(i, e.target.value)}
                    rows={2}
                    className="flex-1 bg-[#1A1628] border border-white/10 rounded-xl px-3 py-2.5 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-amber-500/50 resize-none"
                  />
                  {form.instructions.length > 1 && (
                    <button type="button" onClick={() => removeStep(i)} className="text-red-400 hover:text-red-300 p-1 mt-2">
                      <Trash2 size={14} />
                    </button>
                  )}
                </div>
              ))}
            </div>
          </section>

          <button
            type="submit"
            className="w-full py-3.5 rounded-2xl bg-gradient-to-r from-purple-700 to-purple-500 text-white font-bold text-sm hover:opacity-90 transition-opacity mt-2"
          >
            Submit for Review
          </button>
        </form>
      </FeatureGate>
    </div>
  );
};
